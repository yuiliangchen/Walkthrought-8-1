pageextension 50124 "Customer Card Ext" extends "Customer Card"
{
    layout
    {   
        // The "addlast" construct adds the field control as the last control in the General 
        // group.
        addlast(General)
        {
            field("Reward ID";Rec."Reward ID")
            {
                ApplicationArea = All;

                // Lookup property is used to provide a lookup window for 
                // a text box. It is set to true, because a lookup for 
                // the field is needed.
                Lookup = true;
            }
        }
        addafter(Name) 
        { 
            field(RewardLevel; RewardLevel) 
            { 
                ApplicationArea = All; 
                Caption = 'Reward Level'; 
                Description = 'Reward level of the customer.'; 
                ToolTip = 'Specifies the level of reward that the customer has at this point.';
                Editable = false; 
            } 

            field(RewardPoints; Rec.RewardPoints) 
            { 
                ApplicationArea = All; 
                Caption = 'Reward Points'; 
                Description = 'Reward points accrued by customer'; 
                ToolTip = 'Specifies the total number of points that the customer has at this point.';
                Editable = false;
            }
        }
    }

    actions
    {
        // The "addfirst" construct will add the action as the first action
        // in the Navigation group.
        addfirst(Navigation)
        {
            action("Rewards")
            {
                ApplicationArea = All;

                // "RunObject" sets the "Reward List" page as the object 
                // that will run when the action is activated.
                RunObject = page "Reward List";
            }
        }
        addlast(processing)
        {
            action(UpdateCreditLimit)
            {
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = CalculateCost;
                ApplicationArea = All;
                Caption = 'Update Credit Limit';
                trigger OnAction()
                begin
                    CallUpdateCreditLimit();
                end;
            }
        }

    }
    var
        RewardLevel: Text; 
        Text90001: TextConst ENU = 'Are you sure that you want to set the %1 to %2';
        Text90002: TextConst ENU = 'The credit limit was rounded to %1 to comply with company policies.';
        Text90003: TextConst ENU = 'The credit limit is up to date.';

    trigger OnAfterGetRecord(); 
    var 
        CustomerRewardsMgtExt: Codeunit "Customer Rewards Ext. Mgt."; 
    begin 
        // Get the reward level associated with reward points 
        RewardLevel := CustomerRewardsMgtExt.GetRewardLevel(Rec.RewardPoints); 
    end; 

    local procedure CallUpdateCreditLimit()
    var 
        CreditLimitCalculated: Decimal;
        CreditLimitActual: Decimal;
    begin
        CreditLimitCalculated := Rec.CalculateCreditLimit();
        CreditLimitActual := Rec."Credit Limit (LCY)";
        if CreditLimitCalculated =  CreditLimitActual then 
        begin
            Message(Text90003);
            exit;
        end;
        if GuiAllowed and not Confirm(Text90001, false, Rec.FieldCaption("Credit Limit (LCY)"), CreditLimitCalculated) then
        begin
            exit;
        end;
        if CreditLimitActual <> CreditLimitCalculated then
            Message(Text90002, CreditLimitCalculated); 
        CreditLimitActual := CreditLimitCalculated;
        Rec.UpdateCreditLimit(CreditLimitActual);
    end;
}